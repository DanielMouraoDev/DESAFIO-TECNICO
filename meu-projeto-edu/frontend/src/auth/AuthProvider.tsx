"use client";

import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import {
  ACCESS_COOKIE,
  authLocalStorageKeys,
  clearCookie,
  clearLocalStorageAuth,
  getCookie,
  readLocalStorageAuth,
  setCookie,
  type StoredAuthUser,
  REFRESH_COOKIE,
} from "./authStorage";

type AuthContextValue = {
  accessToken: string | null;
  refreshToken: string | null;
  user: StoredAuthUser | null;
  isHydrated: boolean;
  login: (args: { username: string; password: string }) => Promise<{ ok: true }>;
  logout: () => void;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api";

type AuthState = {
  accessToken: string | null;
  refreshToken: string | null;
  user: StoredAuthUser | null;
  isHydrated: boolean;
};

function getInitialAuthState(): AuthState {
  if (typeof window === "undefined") {
    return {
      accessToken: null,
      refreshToken: null,
      user: null,
      isHydrated: false,
    };
  }

  const cookieAccess = getCookie(ACCESS_COOKIE);
  const cookieRefresh = getCookie(REFRESH_COOKIE);
  const { accessToken: lsAccess, refreshToken: lsRefresh, user: lsUser } = readLocalStorageAuth();

  return {
    accessToken: cookieAccess ?? lsAccess,
    refreshToken: cookieRefresh ?? lsRefresh,
    user: lsUser,
    isHydrated: true,
  };
}

async function loginRequest(args: { username: string; password: string }) {
  const res = await fetch(`${API_BASE_URL}/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });

  const data = (await res.json()) as
    | { access: string; refresh?: string; user: StoredAuthUser }
    | { error: string };

  if (!res.ok) {
    const error = "error" in data ? data.error : "Login failed";
    throw new Error(error);
  }

  if ("error" in data) {
    throw new Error(data.error);
  }

  return data;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();

  const [authState, setAuthState] = useState<AuthState>(() => getInitialAuthState());
  const { accessToken, refreshToken, user, isHydrated } = authState;

  // Keep cookies in sync for middleware checks when state comes from localStorage.
  useEffect(() => {
    if (!isHydrated) return;

    const cookieAccess = getCookie(ACCESS_COOKIE);
    const cookieRefresh = getCookie(REFRESH_COOKIE);

    if (accessToken && !cookieAccess) {
      setCookie(ACCESS_COOKIE, accessToken, { maxAgeSeconds: 60 * 60 });
    }
    if (refreshToken && !cookieRefresh) {
      setCookie(REFRESH_COOKIE, refreshToken, { maxAgeSeconds: 60 * 60 * 24 * 7 });
    }
  }, [accessToken, refreshToken, isHydrated]);

  // Redirect after hydration.
  useEffect(() => {
    if (!isHydrated) return;

    const hasToken = Boolean(accessToken);
    if (!hasToken && pathname?.startsWith("/dashboard")) {
      router.replace(`/login?from=${encodeURIComponent(pathname ?? "/dashboard")}`);
      return;
    }

    if (hasToken && pathname === "/login") {
      router.replace("/dashboard");
    }
  }, [accessToken, isHydrated, pathname, router]);

  const login = useCallback(
    async ({ username, password }: { username: string; password: string }) => {
      const data = await loginRequest({ username, password });

      const nextAccess = data.access;
      const nextRefresh = data.refresh ?? null;
      const nextUser = data.user;

      // Keep both localStorage (client state) and cookies (middleware check) in sync.
      window.localStorage.setItem(authLocalStorageKeys.access, nextAccess);
      window.localStorage.setItem(authLocalStorageKeys.refresh, nextRefresh ?? "");
      window.localStorage.setItem(authLocalStorageKeys.user, JSON.stringify(nextUser));

      setCookie(ACCESS_COOKIE, nextAccess, { maxAgeSeconds: 60 * 60 });
      if (nextRefresh) {
        setCookie(REFRESH_COOKIE, nextRefresh, { maxAgeSeconds: 60 * 60 * 24 * 7 });
      }

      setAuthState({
        accessToken: nextAccess,
        refreshToken: nextRefresh,
        user: nextUser,
        isHydrated: true,
      });

      if (pathname === "/login") {
        router.replace("/dashboard");
      }

      return { ok: true as const };
    },
    [pathname, router]
  );

  const logout = useCallback(() => {
    clearCookie(ACCESS_COOKIE);
    clearCookie(REFRESH_COOKIE);
    clearLocalStorageAuth();

    setAuthState({
      accessToken: null,
      refreshToken: null,
      user: null,
      isHydrated: true,
    });

    router.replace("/login");
  }, [router]);

  const value = useMemo<AuthContextValue>(
    () => ({ accessToken, refreshToken, user, isHydrated, login, logout }),
    [accessToken, refreshToken, user, isHydrated, login, logout]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}


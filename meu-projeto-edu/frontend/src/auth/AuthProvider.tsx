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

  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [user, setUser] = useState<StoredAuthUser | null>(null);
  const [isHydrated, setIsHydrated] = useState(false);

  // Hydrate auth state on refresh (cookie + localStorage).
  useEffect(() => {
    const cookieAccess = getCookie(ACCESS_COOKIE);
    const cookieRefresh = getCookie(REFRESH_COOKIE);

    const { accessToken: lsAccess, refreshToken: lsRefresh, user: lsUser } = readLocalStorageAuth();

    const finalAccess = cookieAccess ?? lsAccess;
    const finalRefresh = cookieRefresh ?? lsRefresh;
    const finalUser = lsUser;

    // If the user has tokens in localStorage but the cookie is missing, sync them
    // so middleware protection on F5 works correctly.
    if (finalAccess && !cookieAccess) {
      setCookie(ACCESS_COOKIE, finalAccess, { maxAgeSeconds: 60 * 60 });
    }
    if (finalRefresh && !cookieRefresh) {
      setCookie(REFRESH_COOKIE, finalRefresh, { maxAgeSeconds: 60 * 60 * 24 * 7 });
    }

    setAccessToken(finalAccess);
    setRefreshToken(finalRefresh);
    setUser(finalUser);
    setIsHydrated(true);
  }, []);

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

      setAccessToken(nextAccess);
      setRefreshToken(nextRefresh);
      setUser(nextUser);

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

    setAccessToken(null);
    setRefreshToken(null);
    setUser(null);

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


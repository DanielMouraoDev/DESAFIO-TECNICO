// App-specific names to avoid collisions with other projects on localhost.
const ACCESS_COOKIE = "mpedu_access";
const REFRESH_COOKIE = "mpedu_refresh";

export { ACCESS_COOKIE, REFRESH_COOKIE };

function readCookie(name: string): string | null {
  if (typeof document === "undefined") return null;
  const match = document.cookie.match(
    new RegExp(`(?:^|; )${name.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")}=([^;]*)`)
  );
  return match ? decodeURIComponent(match[1]) : null;
}

export function getCookie(name: string): string | null {
  return readCookie(name);
}

export function setCookie(
  name: string,
  value: string,
  options?: { maxAgeSeconds?: number; path?: string }
) {
  if (typeof document === "undefined") return;

  const path = options?.path ?? "/";
  const maxAgeSeconds = options?.maxAgeSeconds;

  // Only mark cookies as Secure over HTTPS; local dev typically uses HTTP.
  const secure = typeof window !== "undefined" && window.location.protocol === "https:";

  let cookie = `${name}=${encodeURIComponent(value)}; path=${path}; SameSite=Lax`;
  if (typeof maxAgeSeconds === "number") {
    cookie += `; max-age=${Math.floor(maxAgeSeconds)}`;
  }
  if (secure) cookie += "; Secure";

  document.cookie = cookie;
}

export function clearCookie(name: string) {
  if (typeof document === "undefined") return;
  // Expire immediately.
  document.cookie = `${name}=; path=/; SameSite=Lax; max-age=0`;
}

export type StoredAuthUser = { id: number; username: string; email: string };

// localStorage keys
const LS_ACCESS = "auth.accessToken";
const LS_REFRESH = "auth.refreshToken";
const LS_USER = "auth.user";

export const authLocalStorageKeys = {
  access: LS_ACCESS,
  refresh: LS_REFRESH,
  user: LS_USER,
} as const;

export function readLocalStorageAuth() {
  if (typeof window === "undefined") {
    return { accessToken: null as string | null, refreshToken: null as string | null, user: null as StoredAuthUser | null };
  }

  const accessToken = window.localStorage.getItem(LS_ACCESS);
  const refreshToken = window.localStorage.getItem(LS_REFRESH);
  const userRaw = window.localStorage.getItem(LS_USER);
  const user = userRaw ? (JSON.parse(userRaw) as StoredAuthUser) : null;

  return { accessToken, refreshToken, user };
}

export function writeLocalStorageAuth(args: {
  accessToken: string;
  refreshToken?: string | null;
  user?: StoredAuthUser | null;
}) {
  if (typeof window === "undefined") return;

  window.localStorage.setItem(LS_ACCESS, args.accessToken);
  window.localStorage.setItem(LS_REFRESH, args.refreshToken ?? "");
  window.localStorage.setItem(LS_USER, JSON.stringify(args.user ?? null));
}

export function clearLocalStorageAuth() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(LS_ACCESS);
  window.localStorage.removeItem(LS_REFRESH);
  window.localStorage.removeItem(LS_USER);
}


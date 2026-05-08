"use client";

import React, { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "./AuthProvider";

export function AuthGate({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const { accessToken, isHydrated } = useAuth();

  useEffect(() => {
    if (!isHydrated) return;
    if (!accessToken) router.replace("/login");
  }, [accessToken, isHydrated, router]);

  if (!isHydrated) return null;
  if (!accessToken) return null;

  return <>{children}</>;
}


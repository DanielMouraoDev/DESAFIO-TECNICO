"use client";

import React, { useState } from "react";
import { useAuth } from "@/auth/AuthProvider";
import { useSearchParams } from "next/navigation";

export default function LoginPage() {
  const { login } = useAuth();
  const searchParams = useSearchParams();
  const from = searchParams.get("from");

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setIsSubmitting(true);
    try {
      await login({ username, password });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-black px-4">
      <form
        onSubmit={onSubmit}
        className="w-full max-w-sm rounded-xl border border-black/10 bg-white p-6 dark:border-white/10 dark:bg-zinc-900"
      >
        <h1 className="text-xl font-semibold">Login</h1>
        {from ? (
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
            Sign in to access <code>{from}</code>
          </p>
        ) : null}

        <div className="mt-4 grid gap-3">
          <label className="grid gap-1">
            <span className="text-sm font-medium">Username</span>
            <input
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="h-10 rounded-lg border border-black/10 px-3 dark:border-white/10 dark:bg-zinc-800"
              autoComplete="username"
              required
            />
          </label>

          <label className="grid gap-1">
            <span className="text-sm font-medium">Password</span>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="h-10 rounded-lg border border-black/10 px-3 dark:border-white/10 dark:bg-zinc-800"
              autoComplete="current-password"
              required
            />
          </label>
        </div>

        {error ? (
          <div className="mt-3 text-sm text-red-600 dark:text-red-400">
            {error}
          </div>
        ) : null}

        <button
          disabled={isSubmitting}
          className="mt-5 w-full h-11 rounded-lg bg-black text-white disabled:opacity-50 dark:bg-zinc-100 dark:text-black"
          type="submit"
        >
          {isSubmitting ? "Signing in..." : "Sign in"}
        </button>
      </form>
    </div>
  );
}


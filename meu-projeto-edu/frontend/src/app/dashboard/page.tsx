"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { AuthGate } from "@/auth/AuthGate";
import { useAuth } from "@/auth/AuthProvider";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api";

type Course = {
  id: number;
  title: string;
  description: string;
  active: boolean;
  // Django returns datetime/interval fields but we only display title/description.
};

export default function DashboardPage() {
  return (
    <AuthGate>
      <DashboardContent />
    </AuthGate>
  );
}

function DashboardContent() {
  const { accessToken, user } = useAuth();
  const [courses, setCourses] = useState<Course[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      setLoading(true);
      setError(null);

      try {
        const res = await fetch(`${API_BASE_URL}/courses`, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
        });

        if (!res.ok) {
          setError(`Failed to load courses (HTTP ${res.status}).`);
          setCourses(null);
          return;
        }

        const data = (await res.json()) as Course[];
        setCourses(data);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Failed to load courses.");
        setCourses(null);
      } finally {
        setLoading(false);
      }
    }

    if (accessToken) load();
  }, [accessToken]);

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black px-4 py-8">
      <div className="mx-auto w-full max-w-3xl">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-semibold">Dashboard</h1>
            <p className="mt-1 text-zinc-600 dark:text-zinc-400">
              Signed in as <code>{user?.username ?? "user"}</code>
            </p>
          </div>
          <Link
            href="/dashboard/study"
            className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
          >
            Study Flashcards
          </Link>
        </div>

        <div className="mt-6">
          {loading ? (
            <p className="text-zinc-600 dark:text-zinc-400">Loading...</p>
          ) : error ? (
            <p className="text-red-600 dark:text-red-400">{error}</p>
          ) : courses?.length ? (
            <ul className="grid gap-3">
              {courses.map((c) => (
                <li
                  key={c.id}
                  className="rounded-xl border border-black/10 bg-white p-4 dark:border-white/10 dark:bg-zinc-900"
                >
                  <div className="font-medium">{c.title}</div>
                  <div className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
                    {c.description}
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-zinc-600 dark:text-zinc-400">
              No courses found.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}


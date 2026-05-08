"use client";

import { useAuth } from "@/auth/AuthProvider";
import { useEffect, useState } from "react";

export default function DebugPage() {
  const { accessToken, user, isHydrated } = useAuth();
  const [storageData, setStorageData] = useState<Record<string, any>>({});

  useEffect(() => {
    if (typeof window !== "undefined") {
      setStorageData({
        localStorage: {
          access: window.localStorage.getItem("auth.accessToken")?.substring(0, 50) + "...",
          user: window.localStorage.getItem("auth.user"),
        },
        cookies: document.cookie,
      });
    }
  }, []);

  return (
    <div className="min-h-screen bg-gray-900 text-white p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">🔍 Debug Auth</h1>

        <div className="space-y-6">
          <div className="bg-gray-800 p-6 rounded-lg">
            <h2 className="text-xl font-semibold mb-4">Auth Context</h2>
            <pre className="bg-gray-900 p-4 rounded overflow-auto text-sm">
              {JSON.stringify(
                {
                  isHydrated,
                  accessToken: accessToken ? accessToken.substring(0, 50) + "..." : null,
                  user,
                },
                null,
                2
              )}
            </pre>
          </div>

          <div className="bg-gray-800 p-6 rounded-lg">
            <h2 className="text-xl font-semibold mb-4">Storage</h2>
            <pre className="bg-gray-900 p-4 rounded overflow-auto text-sm">
              {JSON.stringify(storageData, null, 2)}
            </pre>
          </div>

          <div className="bg-gray-800 p-6 rounded-lg">
            <h2 className="text-xl font-semibold mb-4">Test API Request</h2>
            <TestAPICall token={accessToken} />
          </div>
        </div>
      </div>
    </div>
  );
}

function TestAPICall({ token }: { token: string | null }) {
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const testCourses = async () => {
    setLoading(true);
    try {
      const res = await fetch("http://localhost:8000/api/courses", {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      });

      const data = await res.json();
      setResult({
        status: res.status,
        headers: Object.fromEntries(res.headers),
        data,
      });
    } catch (e) {
      setResult({ error: e instanceof Error ? e.message : String(e) });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <button
        onClick={testCourses}
        disabled={loading || !token}
        className="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded font-semibold disabled:opacity-50"
      >
        {loading ? "Testing..." : "Test /api/courses"}
      </button>

      {result && (
        <pre className="bg-gray-900 p-4 rounded mt-4 overflow-auto text-sm">
          {JSON.stringify(result, null, 2)}
        </pre>
      )}

      {!token && <p className="text-red-400 mt-2">❌ Nenhum token encontrado</p>}
    </div>
  );
}

"use client";

import React, { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { AuthGate } from "@/auth/AuthGate";
import { useAuth } from "@/auth/AuthProvider";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api";

type Flashcard = {
  id: number;
  front: string;
  back: string;
  interval: number;
  easiness: number;
  next_review: string;
};

export default function StudyPage() {
  return (
    <AuthGate>
      <StudyContent />
    </AuthGate>
  );
}

function StudyContent() {
  const { accessToken } = useAuth();
  const queryClient = useQueryClient();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [showBack, setShowBack] = useState(false);

  const { data: flashcards, isLoading, error } = useQuery({
    queryKey: ["flashcards", "study"],
    queryFn: async () => {
      const res = await fetch(`${API_BASE_URL}/flashcards/study`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      });
      if (!res.ok) throw new Error("Failed to fetch flashcards");
      return res.json() as Promise<Flashcard[]>;
    },
  });

  const reviewMutation = useMutation({
    mutationFn: async ({ flashcardId, grade }: { flashcardId: number; grade: number }) => {
      const res = await fetch(`${API_BASE_URL}/flashcards/${flashcardId}/review`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ grade }),
      });
      if (!res.ok) throw new Error("Failed to review flashcard");
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["flashcards", "study"] });
      setCurrentIndex(0);
      setShowBack(false);
    },
  });

  if (isLoading) return <div className="p-4">Loading flashcards...</div>;
  if (error) return <div className="p-4 text-red-500">Error: {error.message}</div>;
  if (!flashcards || flashcards.length === 0) {
    return <div className="p-4">No flashcards due for study. Great job!</div>;
  }

  const currentCard = flashcards[currentIndex];

  const handleCardClick = () => {
    if (!showBack) {
      setShowBack(true);
    }
  };

  const handleReview = (grade: number) => {
    reviewMutation.mutate({ flashcardId: currentCard.id, grade });
  };

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-md mx-auto">
        <h1 className="text-2xl font-bold mb-6 text-center">Daily Study</h1>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="mb-4 text-sm text-gray-500">
            Card {currentIndex + 1} of {flashcards.length}
          </div>

          <div
            className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-4 cursor-pointer min-h-[200px] flex items-center justify-center"
            onClick={handleCardClick}
          >
            <div className="text-center">
              {!showBack ? (
                <div>
                  <div className="text-lg font-medium mb-2">Front</div>
                  <div className="text-xl">{currentCard.front}</div>
                  <div className="text-sm text-gray-500 mt-4">Click to reveal answer</div>
                </div>
              ) : (
                <div>
                  <div className="text-lg font-medium mb-2">Back</div>
                  <div className="text-xl">{currentCard.back}</div>
                </div>
              )}
            </div>
          </div>

          {showBack && (
            <div className="space-y-2">
              <button
                onClick={() => handleReview(1)}
                disabled={reviewMutation.isPending}
                className="w-full bg-red-500 hover:bg-red-600 text-white font-medium py-2 px-4 rounded disabled:opacity-50"
              >
                Hard
              </button>
              <button
                onClick={() => handleReview(3)}
                disabled={reviewMutation.isPending}
                className="w-full bg-yellow-500 hover:bg-yellow-600 text-white font-medium py-2 px-4 rounded disabled:opacity-50"
              >
                Medium
              </button>
              <button
                onClick={() => handleReview(5)}
                disabled={reviewMutation.isPending}
                className="w-full bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-4 rounded disabled:opacity-50"
              >
                Easy
              </button>
            </div>
          )}

          {reviewMutation.isPending && (
            <div className="mt-4 text-center text-gray-500">Submitting review...</div>
          )}

          {reviewMutation.isError && (
            <div className="mt-4 text-center text-red-500">
              Error: {reviewMutation.error?.message}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
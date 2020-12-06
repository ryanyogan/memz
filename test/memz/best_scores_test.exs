defmodule Memz.BestScoresTest do
  use Memz.DataCase

  alias Memz.BestScores

  describe "scores" do
    alias Memz.BestScores.Score

    @valid_attrs %{initials: "some initials", score: 42}
    @update_attrs %{initials: "some updated initials", score: 43}
    @invalid_attrs %{initials: nil, score: nil}

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BestScores.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert BestScores.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert BestScores.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = BestScores.create_score(@valid_attrs)
      assert score.initials == "some initials"
      assert score.score == 42
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BestScores.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, %Score{} = score} = BestScores.update_score(score, @update_attrs)
      assert score.initials == "some updated initials"
      assert score.score == 43
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = BestScores.update_score(score, @invalid_attrs)
      assert score == BestScores.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = BestScores.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> BestScores.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = BestScores.change_score(score)
    end
  end
end

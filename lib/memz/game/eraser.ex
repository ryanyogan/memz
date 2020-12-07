defmodule Memz.Game.Eraser do
  defstruct ~w(text schedule score initial_text status)a

  @type t :: %__MODULE__{
          text: binary(),
          schedule: list(),
          score: integer(),
          status: atom()
        }

  @delete_proof ["\n", ",", "."]

  @spec new(binary, number) :: Memz.Game.Eraser.t()
  def new(text, number_of_steps) do
    %__MODULE__{
      text: text,
      schedule: schedule(text, number_of_steps),
      score: 0,
      initial_text: text,
      status: :erasing
    }
  end

  def erase(%{schedule: [to_erase | tail], text: text} = eraser) do
    erased_text =
      text
      |> String.graphemes()
      |> Enum.with_index(1)
      |> Enum.map(fn {char, index} -> maybe_erase(char, index in to_erase) end)
      |> Enum.join("")

    %{eraser | schedule: tail, text: erased_text, status: :guessing}
  end

  def score(eraser, guess) do
    compute_score(eraser, eraser.initial_text, guess)
    |> set_next_status()
  end

  defp set_next_status(%{schedule: []} = eraser) do
    %{eraser | status: :finished}
  end

  defp set_next_status(eraser) do
    %{eraser | status: :erasing}
  end

  @spec done?(any) :: boolean
  def done?(%{steps: []}), do: true
  def done?(_eraser), do: false

  defp compute_score(eraser, actual, guess) do
    score_difference =
      actual
      |> String.myers_difference(guess)
      |> Enum.reject(fn {edit, _} -> edit == :eq end)
      |> Enum.map(fn {_edit, text} -> text end)
      |> Enum.join()
      |> String.length()

    %{eraser | score: eraser.score + score_difference}
  end

  defp maybe_erase(char, _erase) when char in @delete_proof, do: char
  defp maybe_erase(_char, _erase = true), do: "_"
  defp maybe_erase(char, _erase = false), do: char

  defp schedule(text, number_of_steps) do
    size = String.length(text)

    chunk_size =
      size
      |> Kernel./(number_of_steps)
      |> Kernel.ceil()

    1..size
    |> Enum.shuffle()
    |> Enum.chunk_every(chunk_size)
  end
end

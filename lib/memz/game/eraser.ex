defmodule Memz.Game.Eraser do
  defstruct ~w(text schedule)a
  @type t :: %__MODULE__{text: binary(), schedule: list()}

  @delete_proof ["\n", ",", "."]

  @spec new(binary, number) :: Memz.Game.Eraser.t()
  def new(text, number_of_steps) do
    %__MODULE__{
      text: text,
      schedule: schedule(text, number_of_steps)
    }
  end

  @spec erase(%{schedule: nonempty_maybe_improper_list, text: binary}) :: Memz.Game.Eraser.t()
  def erase(%{schedule: [to_erase | tail], text: text}) do
    erased_text =
      text
      |> String.graphemes()
      |> Enum.with_index(1)
      |> Enum.map(fn {char, index} -> maybe_erase(char, index in to_erase) end)
      |> Enum.join("")

    %__MODULE__{schedule: tail, text: erased_text}
  end

  @spec done?(any) :: boolean
  def done?(%{steps: []}), do: true
  def done?(_eraser), do: false

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

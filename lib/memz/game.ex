defmodule Memz.Game do
  defstruct [:text, :steps]

  @type t :: %__MODULE__{text: binary(), steps: integer()}
  @field_types %{text: :string, steps: :integer}

  alias Ecto.Changeset
  alias Memz.Game.Eraser

  @spec new_game(binary(), integer()) :: Memz.Game.t()
  def new_game(text, steps) do
    %__MODULE__{text: text, steps: steps}
  end

  @spec create(%Ecto.Changeset{}) :: Memz.Game.Eraser.t() | any
  def create(%{valid?: true} = changeset) do
    Eraser.new(changeset.changes.text, changeset.changes.steps)
  end

  def create(changeset), do: changeset

  @spec change_game(Memz.Game.t(), any()) :: Ecto.Changeset.t()
  def change_game(game, params) do
    {game, @field_types}
    |> Changeset.cast(params, Map.keys(@field_types))
    |> Changeset.validate_required([:text, :steps])
    |> Changeset.validate_length(:text, min: 4)
    |> Map.put(:action, :validate)
  end

  @spec erase(%{schedule: nonempty_maybe_improper_list, text: binary}) :: Memz.Game.Eraser.t()
  def erase(eraser) do
    Eraser.erase(eraser)
  end

  @spec done?(any) :: boolean
  def done?(eraser) do
    Eraser.done?(eraser)
  end
end

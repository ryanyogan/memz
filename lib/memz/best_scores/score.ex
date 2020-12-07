defmodule Memz.BestScores.Score do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scores" do
    field :initials, :string, null: false
    field :score, :integer

    timestamps()
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:initials, :score])
    |> validate_required([:initials, :score])
    |> validate_length(:initials, min: 3, max: 3)
  end
end

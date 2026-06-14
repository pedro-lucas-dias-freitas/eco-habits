defmodule EcoHabits.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habits" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :points, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :description, :category, :points, :user_id]) # <-- :user_id TEM que estar aqui
    |> validate_required([:name, :description, :category, :points, :user_id]) # <-- E aqui
    |> validate_inclusion(:category, ["alimentação", "transporte", "energia", "água", "resíduos"], message: "selecione uma categoria válida")
    |> validate_number(:points, greater_than_or_equal_to: 0, message: "a pontuação não pode ser negativa")
  end
end

defmodule EcoHabits.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :name, :string
      add :description, :text
      add :category, :string
      add :points, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:habits, [:user_id])
  end
end

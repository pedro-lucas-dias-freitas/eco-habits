defmodule EcoHabits.Repo.Migrations.AddUniqueIndexToCheckins do
  use Ecto.Migration

  def change do
    create unique_index(:checkins, [:user_id, :habit_id, "(date(data_do_checkin))"], name: :checkins_user_habit_date_index)

  end
end

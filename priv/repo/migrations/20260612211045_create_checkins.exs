defmodule EcoHabits.Repo.Migrations.CreateCheckins do
  use Ecto.Migration

  def change do
    create table(:checkins) do
      add :habit_id, :integer
      add :data_do_checkin, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)


      timestamps(type: :utc_datetime)
    end

    create index(:checkins, [:user_id])
    #create unique_index(:checkins, [:user_id, :habit_id, "date(data_do_checkin)"], name: :checkins_user_habit_date_index)

  end
end

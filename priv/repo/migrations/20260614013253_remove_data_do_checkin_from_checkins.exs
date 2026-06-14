defmodule EcoHabits.Repo.Migrations.RemoveDataDoCheckin do
  use Ecto.Migration

  def change do
    # Remove o índice antigo diretamente
    drop index(:checkins, [:user_id, :habit_id, :data_do_checkin], name: :checkins_user_habit_date_index)

    alter table(:checkins) do
      remove :data_do_checkin
    end

    # Cria o novo índice usando inserted_at
    # MySQL exige parênteses duplos para funções em índices
    create unique_index(:checkins, [:user_id, :habit_id, "(date(inserted_at))"], name: :checkins_user_habit_date_index)
  end
end

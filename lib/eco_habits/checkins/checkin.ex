defmodule EcoHabits.Checkins.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do

    belongs_to :user, EcoHabits.Accounts.User
    belongs_to :habit, EcoHabits.Habits.Habit


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(checkin, attrs, user_scope) do
    checkin
    |> cast(attrs, [:habit_id])
    |> validate_required([:habit_id])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:habit_id,
     name: :checkins_user_habit_date_index,
     message: "Você já realizou este hábito hoje!")
  end
end

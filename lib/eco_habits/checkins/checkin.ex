defmodule EcoHabits.Checkins.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do
    field :habit_id, :integer
    field :data_do_checkin, :utc_datetime
    #field :user_id, :id

    belongs_to :user, EcoHabits.Accounts.User


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(checkin, attrs, user_scope) do
    checkin
    |> cast(attrs, [:habit_id, :data_do_checkin])
    |> validate_required([:habit_id, :data_do_checkin])
    |> put_change(:user_id, user_scope.user.id)
    #|> unique_constraint([:user_id, :habit_id, :data_do_checkin],
    #   name: :checkins_user_habit_date_index,
    #   message: "Você já realizou este hábito hoje!")
    |> unique_constraint(:data_do_checkin,
     name: :checkins_user_habit_date_index,
     message: "Você já realizou este hábito hoje!")
  end
end

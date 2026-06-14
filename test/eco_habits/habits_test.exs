defmodule EcoHabits.HabitsTest do
  use EcoHabits.DataCase

  alias EcoHabits.Habits

  describe "habits" do
    alias EcoHabits.Habits.Habit

    import EcoHabits.HabitsFixtures

    @invalid_attrs %{name: nil, description: nil, category: nil, points: nil}

    test "list_habits/0 returns all habits" do
      habit = habit_fixture()
      assert Habits.list_habits() == [habit]
    end

    test "get_habit!/1 returns the habit with given id" do
      habit = habit_fixture()
      assert Habits.get_habit!(habit.id) == habit
    end

    test "create_habit/1 with valid data creates a habit" do
      valid_attrs = %{name: "some name", description: "some description", category: "some category", points: 42}

      assert {:ok, %Habit{} = habit} = Habits.create_habit(valid_attrs)
      assert habit.name == "some name"
      assert habit.description == "some description"
      assert habit.category == "some category"
      assert habit.points == 42
    end

    test "create_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Habits.create_habit(@invalid_attrs)
    end

    test "update_habit/2 with valid data updates the habit" do
      habit = habit_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", category: "some updated category", points: 43}

      assert {:ok, %Habit{} = habit} = Habits.update_habit(habit, update_attrs)
      assert habit.name == "some updated name"
      assert habit.description == "some updated description"
      assert habit.category == "some updated category"
      assert habit.points == 43
    end

    test "update_habit/2 with invalid data returns error changeset" do
      habit = habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Habits.update_habit(habit, @invalid_attrs)
      assert habit == Habits.get_habit!(habit.id)
    end

    test "delete_habit/1 deletes the habit" do
      habit = habit_fixture()
      assert {:ok, %Habit{}} = Habits.delete_habit(habit)
      assert_raise Ecto.NoResultsError, fn -> Habits.get_habit!(habit.id) end
    end

    test "change_habit/1 returns a habit changeset" do
      habit = habit_fixture()
      assert %Ecto.Changeset{} = Habits.change_habit(habit)
    end
  end
end

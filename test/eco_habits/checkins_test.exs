defmodule EcoHabits.CheckinsTest do
  use EcoHabits.DataCase

  alias EcoHabits.Checkins

  describe "checkins" do
    alias EcoHabits.Checkins.Checkin

    import EcoHabits.AccountsFixtures, only: [user_scope_fixture: 0]
    import EcoHabits.CheckinsFixtures

    @invalid_attrs %{habit_id: nil, data_do_checkin: nil}

    test "list_checkins/1 returns all scoped checkins" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      other_checkin = checkin_fixture(other_scope)
      assert Checkins.list_checkins(scope) == [checkin]
      assert Checkins.list_checkins(other_scope) == [other_checkin]
    end

    test "get_checkin!/2 returns the checkin with given id" do
      scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      other_scope = user_scope_fixture()
      assert Checkins.get_checkin!(scope, checkin.id) == checkin
      assert_raise Ecto.NoResultsError, fn -> Checkins.get_checkin!(other_scope, checkin.id) end
    end

    test "create_checkin/2 with valid data creates a checkin" do
      valid_attrs = %{habit_id: 42, data_do_checkin: ~U[2026-06-11 21:10:00Z]}
      scope = user_scope_fixture()

      assert {:ok, %Checkin{} = checkin} = Checkins.create_checkin(scope, valid_attrs)
      assert checkin.habit_id == 42
      assert checkin.data_do_checkin == ~U[2026-06-11 21:10:00Z]
      assert checkin.user_id == scope.user.id
    end

    test "create_checkin/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Checkins.create_checkin(scope, @invalid_attrs)
    end

    test "update_checkin/3 with valid data updates the checkin" do
      scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      update_attrs = %{habit_id: 43, data_do_checkin: ~U[2026-06-12 21:10:00Z]}

      assert {:ok, %Checkin{} = checkin} = Checkins.update_checkin(scope, checkin, update_attrs)
      assert checkin.habit_id == 43
      assert checkin.data_do_checkin == ~U[2026-06-12 21:10:00Z]
    end

    test "update_checkin/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      checkin = checkin_fixture(scope)

      assert_raise MatchError, fn ->
        Checkins.update_checkin(other_scope, checkin, %{})
      end
    end

    test "update_checkin/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Checkins.update_checkin(scope, checkin, @invalid_attrs)
      assert checkin == Checkins.get_checkin!(scope, checkin.id)
    end

    test "delete_checkin/2 deletes the checkin" do
      scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      assert {:ok, %Checkin{}} = Checkins.delete_checkin(scope, checkin)
      assert_raise Ecto.NoResultsError, fn -> Checkins.get_checkin!(scope, checkin.id) end
    end

    test "delete_checkin/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      assert_raise MatchError, fn -> Checkins.delete_checkin(other_scope, checkin) end
    end

    test "change_checkin/2 returns a checkin changeset" do
      scope = user_scope_fixture()
      checkin = checkin_fixture(scope)
      assert %Ecto.Changeset{} = Checkins.change_checkin(scope, checkin)
    end
  end
end

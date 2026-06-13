defmodule EcoHabitsWeb.HabitLiveTest do
  use EcoHabitsWeb.ConnCase

  import Phoenix.LiveViewTest
  import EcoHabits.HabitsFixtures

  @create_attrs %{name: "some name", description: "some description", category: "some category", points: 42}
  @update_attrs %{name: "some updated name", description: "some updated description", category: "some updated category", points: 43}
  @invalid_attrs %{name: nil, description: nil, category: nil, points: nil}
  defp create_habit(_) do
    habit = habit_fixture()

    %{habit: habit}
  end

  describe "Index" do
    setup [:create_habit]

    test "lists all habits", %{conn: conn, habit: habit} do
      {:ok, _index_live, html} = live(conn, ~p"/habits")

      assert html =~ "Listing Habits"
      assert html =~ habit.name
    end

    test "saves new habit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/habits")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Habit")
               |> render_click()
               |> follow_redirect(conn, ~p"/habits/new")

      assert render(form_live) =~ "New Habit"

      assert form_live
             |> form("#habit-form", habit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#habit-form", habit: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/habits")

      html = render(index_live)
      assert html =~ "Habit created successfully"
      assert html =~ "some name"
    end

    test "updates habit in listing", %{conn: conn, habit: habit} do
      {:ok, index_live, _html} = live(conn, ~p"/habits")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#habits-#{habit.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/habits/#{habit}/edit")

      assert render(form_live) =~ "Edit Habit"

      assert form_live
             |> form("#habit-form", habit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#habit-form", habit: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/habits")

      html = render(index_live)
      assert html =~ "Habit updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes habit in listing", %{conn: conn, habit: habit} do
      {:ok, index_live, _html} = live(conn, ~p"/habits")

      assert index_live |> element("#habits-#{habit.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#habits-#{habit.id}")
    end
  end

  describe "Show" do
    setup [:create_habit]

    test "displays habit", %{conn: conn, habit: habit} do
      {:ok, _show_live, html} = live(conn, ~p"/habits/#{habit}")

      assert html =~ "Show Habit"
      assert html =~ habit.name
    end

    test "updates habit and returns to show", %{conn: conn, habit: habit} do
      {:ok, show_live, _html} = live(conn, ~p"/habits/#{habit}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/habits/#{habit}/edit?return_to=show")

      assert render(form_live) =~ "Edit Habit"

      assert form_live
             |> form("#habit-form", habit: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#habit-form", habit: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/habits/#{habit}")

      html = render(show_live)
      assert html =~ "Habit updated successfully"
      assert html =~ "some updated name"
    end
  end
end

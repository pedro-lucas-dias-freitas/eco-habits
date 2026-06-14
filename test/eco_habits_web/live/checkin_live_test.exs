defmodule EcoHabitsWeb.CheckinLiveTest do
  use EcoHabitsWeb.ConnCase

  import Phoenix.LiveViewTest
  import EcoHabits.CheckinsFixtures

  @create_attrs %{habit_id: 42, data_do_checkin: "2026-06-11T21:10:00Z"}
  @update_attrs %{habit_id: 43, data_do_checkin: "2026-06-12T21:10:00Z"}
  @invalid_attrs %{habit_id: nil, data_do_checkin: nil}

  setup :register_and_log_in_user

  defp create_checkin(%{scope: scope}) do
    checkin = checkin_fixture(scope)

    %{checkin: checkin}
  end

  describe "Index" do
    setup [:create_checkin]

    test "lists all checkins", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/checkins")

      assert html =~ "Listing Checkins"
    end

    test "saves new checkin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/checkins")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Checkin")
               |> render_click()
               |> follow_redirect(conn, ~p"/checkins/new")

      assert render(form_live) =~ "New Checkin"

      assert form_live
             |> form("#checkin-form", checkin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#checkin-form", checkin: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/checkins")

      html = render(index_live)
      assert html =~ "Checkin created successfully"
    end

    test "updates checkin in listing", %{conn: conn, checkin: checkin} do
      {:ok, index_live, _html} = live(conn, ~p"/checkins")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#checkins-#{checkin.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/checkins/#{checkin}/edit")

      assert render(form_live) =~ "Edit Checkin"

      assert form_live
             |> form("#checkin-form", checkin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#checkin-form", checkin: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/checkins")

      html = render(index_live)
      assert html =~ "Checkin updated successfully"
    end

    test "deletes checkin in listing", %{conn: conn, checkin: checkin} do
      {:ok, index_live, _html} = live(conn, ~p"/checkins")

      assert index_live |> element("#checkins-#{checkin.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#checkins-#{checkin.id}")
    end
  end

  describe "Show" do
    setup [:create_checkin]

    test "displays checkin", %{conn: conn, checkin: checkin} do
      {:ok, _show_live, html} = live(conn, ~p"/checkins/#{checkin}")

      assert html =~ "Show Checkin"
    end

    test "updates checkin and returns to show", %{conn: conn, checkin: checkin} do
      {:ok, show_live, _html} = live(conn, ~p"/checkins/#{checkin}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/checkins/#{checkin}/edit?return_to=show")

      assert render(form_live) =~ "Edit Checkin"

      assert form_live
             |> form("#checkin-form", checkin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#checkin-form", checkin: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/checkins/#{checkin}")

      html = render(show_live)
      assert html =~ "Checkin updated successfully"
    end
  end
end

defmodule EcoHabits.Checkins do
  @moduledoc """
  The Checkins context.
  """

  import Ecto.Query, warn: false
  alias EcoHabits.Repo

  alias EcoHabits.Checkins.Checkin
  alias EcoHabits.Accounts.Scope

  @topic "community_feed"


  @doc """
  Subscribes to scoped notifications about any checkin changes.

  The broadcasted messages match the pattern:

    * {:created, %Checkin{}}
    * {:updated, %Checkin{}}
    * {:deleted, %Checkin{}}

  """
  def subscribe_checkins(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(EcoHabits.PubSub, "user:#{key}:checkins")
  end

  defp broadcast_checkin(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(EcoHabits.PubSub, "user:#{key}:checkins", message)
  end

  @doc """
  Returns the list of checkins.

  ## Examples

      iex> list_checkins(scope)
      [%Checkin{}, ...]

  """
  def list_checkins(current_scope) do
    user_id = current_scope.user.id

    Checkin
    |> where(user_id: ^user_id)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
    |> Repo.preload(:habit) # Carrega os dados do hábito
  end

  @doc """
  Gets a single checkin.

  Raises `Ecto.NoResultsError` if the Checkin does not exist.

  ## Examples

      iex> get_checkin!(scope, 123)
      %Checkin{}

      iex> get_checkin!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_checkin!(current_scope, id) do
    Checkin
    |> where(user_id: ^current_scope.user.id)
    |> Repo.get!(id)
    |> Repo.preload(:habit) # Adicione esta linha
  end

  @doc """
  Creates a checkin.

  ## Examples

      iex> create_checkin(scope, %{field: value})
      {:ok, %Checkin{}}

      iex> create_checkin(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_checkin(%Scope{} = scope, attrs) do
    with {:ok, checkin = %Checkin{}} <-
           %Checkin{}
           |> Checkin.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_checkin(scope, {:created, checkin})
      {:ok, checkin}
    end
  end

  @doc """
  Updates a checkin.

  ## Examples

      iex> update_checkin(scope, checkin, %{field: new_value})
      {:ok, %Checkin{}}

      iex> update_checkin(scope, checkin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_checkin(%Scope{} = scope, %Checkin{} = checkin, attrs) do
    true = checkin.user_id == scope.user.id

    with {:ok, checkin = %Checkin{}} <-
           checkin
           |> Checkin.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_checkin(scope, {:updated, checkin})
      {:ok, checkin}
    end
  end

  @doc """
  Deletes a checkin.

  ## Examples

      iex> delete_checkin(scope, checkin)
      {:ok, %Checkin{}}

      iex> delete_checkin(scope, checkin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_checkin(%Scope{} = scope, %Checkin{} = checkin) do
    true = checkin.user_id == scope.user.id

    with {:ok, checkin = %Checkin{}} <-
           Repo.delete(checkin) do
      broadcast_checkin(scope, {:deleted, checkin})
      {:ok, checkin}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking checkin changes.

  ## Examples

      iex> change_checkin(scope, checkin)
      %Ecto.Changeset{data: %Checkin{}}

  """
  def change_checkin(%Scope{} = scope, %Checkin{} = checkin, attrs \\ %{}) do
    true = checkin.user_id == scope.user.id

    Checkin.changeset(checkin, attrs, scope)
  end


  def subscribe_community do
    Phoenix.PubSub.subscribe(EcoHabits.PubSub, @topic)
  end

  defp broadcast_community({:ok, checkin}, event) do
  # Carrega os dados do usuário antes de enviar para o PubSub
  checkin_with_user = Repo.preload(checkin, :user)
  Phoenix.PubSub.broadcast(EcoHabits.PubSub, @topic, {event, checkin_with_user})
  {:ok, checkin}
  end

defp broadcast_community(error, _event), do: error
end

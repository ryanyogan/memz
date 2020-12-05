defmodule MemzWeb.GameLive.Welcome do
  use MemzWeb, :live_view

  alias Memz.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(changeset: Game.change_game(Game.new_game("", 5), %{}))
     |> assign(submitted: false)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h1>What do you want to memorize?</h1>
    <pre>
      <%= inspect @changeset %>
      <%= inspect @submitted %>
    </pre>

    <%= f = form_for @changeset, "#",
        phx_change: "validate",
        phx_submit: "save" %>

      <%= label f, :steps %>
      <%= number_input f, :steps %>
      <%= error_tag f, :steps %>

      <%= label f, :text %>
      <%= text_input f, :text %>
      <%= error_tag f, :text %>

      <%= submit "Memorize", phx_disabled_with: "Saving..." %>
    </form>
    """
  end

  defp validate(socket, params) do
    socket
    |> assign(changeset: Game.change_game(Game.new_game("", 5), params))
  end

  defp memorize(socket, params) do
    socket
    |> assign(submitted: true)
  end

  @impl true
  def handle_event("validate", %{"game" => params}, socket) do
    {:noreply, validate(socket, params)}
  end

  @impl true
  def handle_event("save", %{"game" => params}, socket) do
    {:noreply, memorize(socket, params)}
  end
end

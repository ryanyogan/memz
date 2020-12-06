defmodule MemzWeb.GameLive.Play do
  use MemzWeb, :live_view

  alias Memz.Game

  @default_text ""
  @default_steps 0

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(changeset: Game.change_game(default_game(), %{}))
     |> assign(eraser: nil)
     |> assign(submitted: false)}
  end

  @impl true
  def render(%{eraser: nil} = assigns) do
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

      <%= submit "Memorize", disabled: !@changeset.valid? %>
    </form>
    """
  end

  def render(assigns) do
    ~L"""
    <h1>Memorize this much!</h1>
    <pre>
      <%= @eraser.text %>
    </pre>
    <button phx-click="erase">Erase some</button>
    """
  end

  defp validate(socket, params) do
    socket
    |> assign(changeset: Game.change_game(default_game(), params))
  end

  defp memorize(socket, params) do
    eraser =
      default_game()
      |> Game.change_game(params)
      |> Game.create()

    socket
    |> assign(eraser: eraser)
  end

  defp default_game(), do: Game.new_game(@default_text, @default_steps)

  defp erase(socket) do
    socket
    |> assign(eraser: Game.erase(socket.assigns.eraser))
  end

  @impl true
  def handle_event("validate", %{"game" => params}, socket) do
    {:noreply, validate(socket, params)}
  end

  @impl true
  def handle_event("save", %{"game" => params}, socket) do
    {:noreply, memorize(socket, params)}
  end

  @impl true
  def handle_event("erase", _params, socket) do
    {:noreply, erase(socket)}
  end
end

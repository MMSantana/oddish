defmodule OddishWeb.GrazeLive.History do
  use OddishWeb, :live_view

  alias Oddish.Grazes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Histórico de manejos
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/grazes/new"}>
            <.icon name="hero-plus" /> Novo manejo
          </.button>
        </:actions>
      </.header>

      <.table
        id="grazes"
        rows={@streams.grazes}
        row_click={
          fn {_id, graze} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}")
          end
        }
      >
        <:col :let={{_id, graze}} label="Solta">{graze.solta.name}</:col>
        <:col :let={{_id, graze}} label="Data inicial">{graze.start_date}</:col>
        <:col :let={{_id, graze}} label="Duração planejada">{graze.planned_period} dias</:col>
        <:col :let={{_id, graze}} label="Data final">{graze.end_date}</:col>
        <:col :let={{_id, graze}} label="Lote">{graze.pack.name}</:col>
        <:col :let={{_id, graze}} label="Status">
          {Oddish.Grazes.Graze.present_status(graze.status)}
        </:col>
        <:col :let={{_id, graze}} label="Terminado em dia?"><.on_time? graze={graze} /></:col>
        <:action :let={{_id, graze}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}"}>Show</.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}/edit"}>
            Editar
          </.link>
        </:action>
        <:action :let={{id, graze}}>
          <.link
            phx-click={JS.push("delete", value: %{id: graze.id}) |> hide("##{id}")}
            data-confirm="Tem certeza que deseja deletar este manejo?"
          >
            Deletar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Grazes.subscribe_grazes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Histórico de manejos")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = [
      pack_id: parse_id(params["pack"]),
      solta_id: parse_id(params["solta"])
    ]

    grazes =
      Oddish.Grazes.list_grazes(socket.assigns.current_scope, filters)
      |> Oddish.Repo.preload([:solta, :pack])

    {:noreply, stream(socket, :grazes, grazes)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    graze = Grazes.get_graze!(socket.assigns.current_scope, id)
    {:ok, _} = Grazes.delete_graze(socket.assigns.current_scope, graze)

    {:noreply, stream_delete(socket, :grazes, graze)}
  end

  @impl true
  def handle_info({type, %Oddish.Grazes.Graze{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :grazes, list_grazes(socket.assigns.current_scope), reset: true)}
  end

  defp list_grazes(current_scope) do
    Grazes.list_grazes(current_scope) |> Oddish.Repo.preload([:solta, :pack])
  end

  defp parse_id(nil), do: nil
  defp parse_id(""), do: nil
  defp parse_id(id), do: id

  defp on_time?(assigns) do
    ~H"""
    <div class={
      cond do
        @graze.end_date == nil ->
          "badge badge-warning"

        !Date.before?(Date.add(@graze.start_date, @graze.planned_period), @graze.end_date) ->
          "badge badge-success"

        true ->
          "badge badge-error"
      end
    }>
    </div>
    """
  end
end

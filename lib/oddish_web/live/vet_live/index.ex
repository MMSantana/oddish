defmodule OddishWeb.VetLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Vets
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/vets/new"}>
            <.icon name="hero-plus" /> New Vet
          </.button>
        </:actions>
      </.header>

      <.table
        id="vets"
        rows={@streams.vets}
        row_click={
          fn {_id, vet} -> JS.navigate(~p"/o/#{@current_scope.organization.slug}/vets/#{vet}") end
        }
      >
        <:col :let={{_id, vet}} label="Name">{vet.name}</:col>
        <:col :let={{_id, vet}} label="Telephone">{vet.telephone}</:col>
        <:col :let={{_id, vet}} label="Email">{vet.email}</:col>
        <:action :let={{_id, vet}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/vets/#{vet}"}>Show</.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/vets/#{vet}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, vet}}>
          <.link
            phx-click={JS.push("delete", value: %{id: vet.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_vets(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Vets")
     |> stream(:vets, list_vets(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    vet = Medicine.get_vet!(socket.assigns.current_scope, id)
    {:ok, _} = Medicine.delete_vet(socket.assigns.current_scope, vet)

    {:noreply, stream_delete(socket, :vets, vet)}
  end

  @impl true
  def handle_info({type, %Oddish.Medicine.Vet{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :vets, list_vets(socket.assigns.current_scope), reset: true)}
  end

  defp list_vets(current_scope) do
    Medicine.list_vets(current_scope)
  end
end

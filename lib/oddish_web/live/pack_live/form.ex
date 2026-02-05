defmodule OddishWeb.PackLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Packs
  alias Oddish.Packs.Pack

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage pack records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="pack-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:flock_type]} type="text" label="Flock type" />
        <.input field={@form[:animal_count]} type="number" label="Animal count" />
        <.input field={@form[:status]} type="text" label="Status" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Pack</.button>
          <.button navigate={return_path(@current_scope, @return_to, @pack)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    pack = Packs.get_pack!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Pack")
    |> assign(:pack, pack)
    |> assign(:form, to_form(Packs.change_pack(socket.assigns.current_scope, pack)))
  end

  defp apply_action(socket, :new, _params) do
    pack = %Pack{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "New Pack")
    |> assign(:pack, pack)
    |> assign(:form, to_form(Packs.change_pack(socket.assigns.current_scope, pack)))
  end

  @impl true
  def handle_event("validate", %{"pack" => pack_params}, socket) do
    changeset = Packs.change_pack(socket.assigns.current_scope, socket.assigns.pack, pack_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"pack" => pack_params}, socket) do
    save_pack(socket, socket.assigns.live_action, pack_params)
  end

  defp save_pack(socket, :edit, pack_params) do
    case Packs.update_pack(socket.assigns.current_scope, socket.assigns.pack, pack_params) do
      {:ok, pack} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pack updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, pack)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_pack(socket, :new, pack_params) do
    case Packs.create_pack(socket.assigns.current_scope, pack_params) do
      {:ok, pack} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pack created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, pack)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _pack), do: ~p"/o/#{scope.organization.slug}/packs"
  defp return_path(scope, "show", pack), do: ~p"/o/#{scope.organization.slug}/packs/#{pack}"
end

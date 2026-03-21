defmodule OddishWeb.VetLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Medicine
  alias Oddish.Medicine.Vet

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage vet records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="vet-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:telephone]} type="text" label="Telephone" />
        <.input field={@form[:email]} type="text" label="Email" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Vet</.button>
          <.button navigate={return_path(@current_scope, @return_to, @vet)}>Cancel</.button>
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
    vet = Medicine.get_vet!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Vet")
    |> assign(:vet, vet)
    |> assign(:form, to_form(Medicine.change_vet(socket.assigns.current_scope, vet)))
  end

  defp apply_action(socket, :new, _params) do
    vet = %Vet{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "New Vet")
    |> assign(:vet, vet)
    |> assign(:form, to_form(Medicine.change_vet(socket.assigns.current_scope, vet)))
  end

  @impl true
  def handle_event("validate", %{"vet" => vet_params}, socket) do
    changeset = Medicine.change_vet(socket.assigns.current_scope, socket.assigns.vet, vet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"vet" => vet_params}, socket) do
    save_vet(socket, socket.assigns.live_action, vet_params)
  end

  defp save_vet(socket, :edit, vet_params) do
    case Medicine.update_vet(socket.assigns.current_scope, socket.assigns.vet, vet_params) do
      {:ok, vet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vet updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, vet)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_vet(socket, :new, vet_params) do
    case Medicine.create_vet(socket.assigns.current_scope, vet_params) do
      {:ok, vet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vet created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, vet)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _vet), do: ~p"/o/#{scope.organization.slug}/vets"
  defp return_path(scope, "show", vet), do: ~p"/o/#{scope.organization.slug}/vets/#{vet}"
end

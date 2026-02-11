defmodule OddishWeb.BovineLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Cattle
  alias Oddish.Cattle.Bovine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="bovine-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Nome" />
        <.input field={@form[:registration_number]} type="text" label="Número de registro" />
        <.input
          field={@form[:gender]}
          type="select"
          options={
            Ecto.Enum.values(Oddish.Cattle.Bovine, :gender)
            |> Enum.map(fn gender -> {Oddish.Cattle.Bovine.present_gender(gender), gender} end)
          }
          prompt="--"
          label="Gênero"
        />
        <.input
          field={@form[:mother_id]}
          type="select"
          options={@mothers}
          prompt="--"
          label="Mãe"
        />
        <.input
          field={@form[:status]}
          type="select"
          options={
            Ecto.Enum.values(Oddish.Cattle.Bovine, :status)
            |> Enum.map(fn status -> {Oddish.Cattle.Bovine.present_status(status), status} end)
          }
          prompt="--"
          label="Status"
        />
        <.input
          field={@form[:pack_id]}
          type="select"
          options={@active_packs}
          prompt="--"
          label="Lote"
        />
        <.input field={@form[:date_of_birth]} type="date" label="Data de nascimento" />
        <.input field={@form[:description]} type="text" label="Descrição" />
        <.input field={@form[:observation]} type="textarea" label="Observação" />
        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar</.button>
          <.button navigate={return_path(@current_scope, @return_to, @bovine)}>Cancelar</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    mothers =
      Cattle.list_cows(socket.assigns.current_scope)
      |> Enum.map(fn mother -> {mother.name, mother.id} end)

    active_packs =
      Oddish.Packs.list_active_packs(socket.assigns.current_scope)
      |> Enum.map(fn pack -> {pack.name, pack.id} end)

    {:ok,
     socket
     |> assign(:mothers, mothers)
     |> assign(:active_packs, active_packs)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    bovine = Cattle.get_bovine!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar")
    |> assign(:bovine, bovine)
    |> assign(:form, to_form(Cattle.change_bovine(socket.assigns.current_scope, bovine)))
  end

  defp apply_action(socket, :new, _params) do
    bovine = %Bovine{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "Novo animal")
    |> assign(:bovine, bovine)
    |> assign(:form, to_form(Cattle.change_bovine(socket.assigns.current_scope, bovine)))
  end

  @impl true
  def handle_event("validate", %{"bovine" => bovine_params}, socket) do
    changeset =
      Cattle.change_bovine(socket.assigns.current_scope, socket.assigns.bovine, bovine_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bovine" => bovine_params}, socket) do
    save_bovine(socket, socket.assigns.live_action, bovine_params)
  end

  defp save_bovine(socket, :edit, bovine_params) do
    case Cattle.update_bovine(socket.assigns.current_scope, socket.assigns.bovine, bovine_params) do
      {:ok, bovine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Animal editado com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bovine)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bovine(socket, :new, bovine_params) do
    case Cattle.create_bovine(socket.assigns.current_scope, bovine_params) do
      {:ok, bovine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Animal criado com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bovine)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _bovine), do: ~p"/o/#{scope.organization.slug}/bovines"
  defp return_path(scope, "show", bovine), do: ~p"/o/#{scope.organization.slug}/bovines/#{bovine}"
end

defmodule Oddish.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Oddish.Repo
  alias Oddish.Accounts.Organization

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :tier, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :tier])
    |> validate_required([:name, :slug, :tier])
  end

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  def get_organization_by_slug!(slug) do
    Repo.get_by(Organization, slug: slug)
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  import Ecto.Query, warn: false

  def user_belongs?(user_id, organization_id) do
    Repo.exists?(
      from uo in Oddish.Accounts.UserOrganization,
        where: uo.user_id == ^user_id and uo.organization_id == ^organization_id
    )
  end

  def user_belongs?(user_id, organization_id, role) do
    Repo.exists?(
      from uo in Oddish.Accounts.UserOrganization,
        where:
          uo.user_id == ^user_id and uo.organization_id == ^organization_id and uo.role == ^role
    )
  end

  def get_organization_by_slug!(org_slug, %Oddish.Accounts.Scope{user: %{id: user_id}}) do
    organization = Repo.get_by!(Organization, slug: org_slug)

    if user_belongs?(user_id, organization.id) do
      organization
    else
      {:error, :unauthorized}
    end
  end
end


class TspotSitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site, only: [:show, :edit, :update, :disown]

  # GET /tspot_sites
  def index
    redirect_to sites_path
  end

  # GET /tspot_sites/1
  def show
  end

  # GET /tspot_sites/1/edit
  def edit
  end

  # PATCH/PUT /tspot_sites/1
  def update
    respond_to do |format|
      if @site.update(site_params_for_update)
        format.html { redirect_to sites_url, notice: 'Site was successfully updated.' }
        # format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        # format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /tspot_sites/claim_form
  def claim_form
  end

  # POST /tspot_sites/claim
  def claim
    return redirect_to action: :claim_form \
      unless @site_name = params[:site_name].strip.presence

    @site = TspotSite.find_or_create(@site_name, request.ip)

    if !@site.exists?
      @message = "'#{@site_name}' does not exist on Tiddlyspot"

    elsif @site.user.present?
      if @site.user == current_user
        @message = "'#{@site_name}' is already owned by you"
      else
        @message = "'#{@site_name}' is owned by someone else"
      end

    elsif @site.passwd_ok?(@site_name, params[:password])
      @site.update(user_id: current_user.id)
      @success = true
      @message = "'#{@site_name}' site ownership claimed successfully"

    else
      @message = "Claim unsuccessful"
    end
  end

  # POST /tspot_sites/1/disown
  def disown
    @site.update(user_id: nil)
    redirect_to sites_path
  end

  private

  def set_site
    @site = current_user.tspot_sites.find(params[:id])
    redirect_to sites_url, notice: 'Site not found' unless @site
  end

  def site_params_for_update
    params.require(:tspot_site).permit(:name, :description, :is_private, :is_searchable, :tag_list)
  end

end
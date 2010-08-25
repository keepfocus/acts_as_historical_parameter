require File.dirname(__FILE__) + '/test_helper'

class DummyInstallationsController < ActionController::Base
  def rescue_action(e)
    raise e
  end

  def show
  end

  def update
    @installation = DummyInstallation.find(params[:id])
    return if handle_add_value(@installation, :area_history, params[:installation])

    respond_to do |format|
      if @installation.update_attributes(params[:installation])
        format.html { redirect_to(dummy_installation_path(@installation)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end

class TestHistoricalControllerAddons < ActionController::TestCase
  tests DummyInstallationsController

  def setup
    ActionController::Routing::Routes.draw {|map| map.resources :dummy_installations }
    @routes = Rails.application.routes
  end

  test "Update works for value add" do
    @installation = DummyInstallation.create(:name => "original")
      
    put :update, :id => @installation.to_param, :add_area_history_value => "test", :installation => {
      :name => "changed"
    }
    assert_response :success
    assert_not_nil assigns(:installation)
    assert assigns(:installation).area_history.last.new_record?
    assert_equal "changed", assigns(:installation).name
    assert_equal "original", DummyInstallation.find(@installation.to_param).name
  end

  test "Update works for save new state" do
    @installation = DummyInstallation.create(:name => "original")
    put :update, :id => @installation.to_param, :installation => {
      :area_history_attributes => [
        {:value => 42, :valid_from => Time.zone.local(2010, 1, 1)},
        {:value => 42, :valid_from => Time.zone.local(2010, 2, 1)}
      ],
      :name => "changed"
    }
    assert_redirected_to dummy_installation_path(@installation)
    assert_equal "changed", DummyInstallation.find(@installation.to_param).name
    assert_equal 42, DummyInstallation.find(@installation.to_param).area
  end
end

require "spec_helper"

describe StreamsController do
  describe "routing" do

    it "routes to #index" do
      get("/streams").should route_to("streams#index")
    end

    it "routes to #new" do
      get("/streams/new").should route_to("streams#new")
    end

    it "routes to #show" do
      get("/streams/1").should route_to("streams#show", :id => "1")
    end

    it "routes to #edit" do
      get("/streams/1/edit").should route_to("streams#edit", :id => "1")
    end

    it "routes to #create" do
      post("/streams").should route_to("streams#create")
    end

    it "routes to #update" do
      put("/streams/1").should route_to("streams#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/streams/1").should route_to("streams#destroy", :id => "1")
    end

  end
end

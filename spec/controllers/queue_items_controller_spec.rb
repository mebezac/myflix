require 'spec_helper'

describe QueueItemsController do
  describe "GET index" do
    it "sets the @queue_items for the current, logged in user" do
      fake_user = Fabricate(:user)
      session[:user_id] = fake_user.id
      video1 = Fabricate(:video)
      video2 = Fabricate(:video)
      queue_item1 = Fabricate(:queue_item, video: video1, user: fake_user)
      queue_item2 = Fabricate(:queue_item, video: video2, user: fake_user)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end
    it "redirects to the sign in page for unauthenticated users" do
      get :index
      expect(response).to redirect_to :sign_in
    end
  end

  describe "POST create" do
    context "with authenticated user" do
      let(:fake_user) { Fabricate(:user) }
      let(:fake_video) { Fabricate(:video) }
      before { session[:user_id] = fake_user.id }
      it "redirects to the My Queue path " do
        post :create, video_id: fake_video.id
        expect(response).to redirect_to :my_queue
      end
      it "creates a queue item" do
        post :create, video_id: fake_video.id
        expect(QueueItem.count).to eq(1)
      end
      it "creates a queue item associated with the video" do
        post :create, video_id: fake_video.id
        expect(QueueItem.first.video_id).to eq(fake_video.id)
      end
      it "creates a queue item associated with the user" do
        post :create, video_id: fake_video.id
        expect(QueueItem.first.user_id).to eq(fake_user.id)
      end
      it "puts the queue item at the end of the que list" do
        video2 = Fabricate(:video)
        Fabricate(:queue_item, video: video2, user: fake_user)
        post :create, video_id: fake_video.id
        expect(QueueItem.last.position).to eq(2)
      end
      it "does not add a video to the queue if that video is already in the queue" do
        Fabricate(:queue_item, video: fake_video, user: fake_user)
        post :create, video_id: fake_video.id
        expect(QueueItem.count).to eq(1)
      end

      it "redirects to the video page if the video is alread in the queue" do
        Fabricate(:queue_item, video: fake_video, user: fake_user)
        post :create, video_id: fake_video.id
        expect(response).to redirect_to video_path(fake_video)
      end

    end
    context "with unauthenticated user" do
      it "redirects to the sign in page" do
        post :create, video_id: 3
        expect(response).to redirect_to :sign_in
      end
    end
  end

  describe "DELETE destroy" do
    let(:fake_video) { Fabricate(:video) }
    let(:fake_user) { Fabricate(:user) }
    let(:fake_queue_item) { Fabricate(:queue_item, video: fake_video, user: fake_user) }
     context "with authenticated user" do
      before { session[:user_id] = fake_user.id }
      it "redirects to the queue page" do
        delete :destroy, id: fake_queue_item
        expect(response).to redirect_to :my_queue
      end
      it "deletes the queue item" do
        delete :destroy, id: fake_queue_item
        expect(QueueItem.count).to eq(0)
      end
      it "can not delete the queue item for another user" do
        other_user = Fabricate(:user)
        session[:user_id] = other_user.id
        delete :destroy, id: fake_queue_item
        expect(QueueItem.count).to eq(1)
      end
    end
    context 'with unauthenticated user' do
      it "redirects unauthenticated users to sign in page" do
        delete :destroy, id: fake_queue_item
        expect(response).to redirect_to :sign_in
      end
    end
  end
  
end
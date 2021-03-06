shared_examples "requires sign in" do
  it "redirects to the sign in page" do
    session[:user_id] = nil
    action
    expect(response).to redirect_to :sign_in
  end
end

shared_examples "requires admin" do
  it "redirects non-admin user to home path" do
    set_current_user
    action
    expect(response).to redirect_to :home
  end
end

shared_examples "tokeable" do
  it "generates a random token when a new object is created" do
    expect(object.token).to be_present
  end
end
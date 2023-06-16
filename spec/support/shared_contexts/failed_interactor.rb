shared_examples :failed_interactor do
  it "failures" do
    interactor.run

    expect(context).to be_failure
    expect(context.error).to eq(error_message)
  end
end

class AuthController < ApplicationController
  include Trailblazer::Endpoint::Controller.module(dsl: true, application_controller: true)


  class Protocol < Trailblazer::Endpoint::Protocol
    def authenticate(*); true; end
    def policy(*); true; end
  end

  endpoint protocol: Protocol, adapter: Trailblazer::Endpoint::Adapter::Web
    # domain_ctx_filter: ApplicationController.current_user_in_domain_ctx

  endpoint Trailblazer::Operation # FIXME
  endpoint Auth::Operation::CreateAccount

  def signup_form
    ctx = {}
    # render html: cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)


    endpoint Trailblazer::Operation do |ctx|
      render html: cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)
    end
  end

  # problem: {params[:signup]} could be nil
  #       passing all variables is cumbersome
  def signup
    endpoint Auth::Operation::CreateAccount, **{email: params[:signup][:email], password: params[:signup][:password], password_confirm: params[:signup][:password_confirm]} do |ctx|
      render cell(Auth::SignUp::Cell::Success, ctx, layout: Layout::Cell::Authentication)
      return
    end.Or do |ctx|
      render cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)
    end
  end
end

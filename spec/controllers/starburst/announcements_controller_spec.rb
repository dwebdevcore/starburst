# frozen_string_literal: true

RSpec.describe Starburst::AnnouncementsController do
  routes { Starburst::Engine.routes }

  describe '#mark_as_read' do
    subject(:mark_as_read) do
      if Rails::VERSION::MAJOR < 5
        post :mark_as_read, **params
      else
        post :mark_as_read, params: params
      end
    end

    let(:announcement) { create(:announcement) }
    let(:params) { Hash[id: announcement.id] }

    before { allow(controller).to receive(:current_user).and_return(current_user) }

    context 'with a signed in User' do
      let(:current_user) { instance_double(User, id: 10) }

      context 'when the User has not marked the Announcement as read yet' do
        let(:announcement_view) { an_object_having_attributes(user_id: current_user.id) }

        it { expect(mark_as_read).to have_http_status(:ok) }

        it 'marks the Announcement as viewed by the signed in User' do
          expect { mark_as_read }.to change(Starburst::AnnouncementView, :all).to contain_exactly(announcement_view)
        end
      end

      context 'when the User has already marked the Announcement as read' do
        before { create(:announcement_view, user_id: current_user.id, announcement: announcement) }

        it { expect(mark_as_read).to have_http_status(:ok) }
        it { expect { mark_as_read }.not_to change(Starburst::AnnouncementView, :count) }
      end
    end

    context 'without a signed in User' do
      let(:current_user) { nil }

      it { expect(mark_as_read).to have_http_status(:unprocessable_entity) }
      it { expect { mark_as_read }.not_to change(Starburst::AnnouncementView, :count) }
    end
  end
end

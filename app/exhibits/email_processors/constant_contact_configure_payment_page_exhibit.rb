module EmailProcessors
  class ConstantContactConfigurePaymentPageExhibit < LinkingBasePageExhibit
    def setup_page
      define :input_text, with: :inline_input_editor

      around COMPONENTS do |content_block|
        view.form_tag view_model.credit_card_processor_path, autocomplete: "off" do
          view.hidden_field_tag(:tr_data, view_model.credit_card_customer_information) +
          content_block.call
        end
      end

      define PRICING_MESSAGE,
        wrapper: CONTENT_TAG_WRAPPER_BLOCK,
        wrapper_tag: :p,
        wrap_all: :column

      append PRICING_MESSAGE do |options|
        # TODO: LINK TO MODAL
        view.link_to options[:component].display_name, 'javascript: alert("Open Modal here")', tabindex: 1
      end

      define CREDIT_CARD_NUMBER_FIELD,
        input_html: {
          value: view_model.credit_card_number,
          name: view_model.credit_card_number_field_name
        },
        input_wrapper_html: {
          class: "col-lg-4 col-md-4 col-sm-5 col-xs-12 creditCardInputWrapperInlineEdit"
        }
      define CREDIT_CARD_EXPIRATION_FIELD,
        input_html: {
          value: view_model.credit_card_expiration,
          name: view_model.credit_card_expiration_field_name,
          data: {
            revert_value: view_model.credit_card_expiration(use_original: true)
          }
        },
        input_wrapper_html: {
          class: "col-lg-2 col-md-2 col-sm-2 col-xs-4 creditCardInputWrapperInlineEdit"
        }
      define CREDIT_CARD_CVV_FIELD,
        input_html: {
          value: view_model.credit_card_cvv,
          name: view_model.credit_card_cvv_field_name
        },
        input_wrapper_html: {
          class: "col-lg-2 col-md-2 col-sm-2 col-xs-4 creditCardInputWrapperInlineEdit"
        }
      define CREDIT_CARD_ZIPCODE_FIELD,
        input_html: {
          value: view_model.credit_card_zipcode,
          name: view_model.credit_card_zipcode_field_name,
          data: {
            revert_value: view_model.credit_card_zipcode(use_original: true)
          }
        },
        input_wrapper_html: {
          class: "col-lg-2 col-md-2 col-sm-3 col-xs-4 creditCardInputWrapperInlineEdit"
        }

      define WIZARD_TITLE, content: view_model.save_card_title
      define WIZARD_NEXT_BUTTON, link_html: { id: "verifyCard", style: "display: none" }
      after WIZARD_NEXT_BUTTON, with: :submit_button, link_html: { id: "saveCard" }, link_text: view_model.save_card_text

      define MAIN_SECTION,
        xs: 12,
        sm: 8,
        md: 8,
        lg: 6,
        offsets: { md: 2, lg: 3, sm: 2 },
        wrapper: :column

      super # must be called
    end
  end
end
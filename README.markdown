ActsAsHistoricalParameter
=========================

System and models for working with historically changeing parameters.


Installation
============

You will need to isert the following javascript into your application.js:

    jQuery(function() {
      jQuery('.destroy_historical_value').each(function() {
        var cell = jQuery(this);
        cell.children().hide();
        var button = document.createElement("input");
        jQuery(button).attr("type", "submit");
        jQuery(button).val("Remove");
        jQuery(button).addClass("remove_historical_value_button");
        cell.append(button);
      });

      jQuery(".remove_historical_value_button").live("click", function(event) {
        event.preventDefault();
        var row = jQuery(this).closest("tr")
        row.hide();
        row.find("input[type=hidden]").val(1);
      });

      jQuery('.add_historical_value').click(function(event) {
        event.preventDefault();
        var assoc   = jQuery(this).attr('data-association');
        var content = jQuery('#' + assoc + '_fields_template tbody').html();
        var regexp  = new RegExp('new_' + assoc, 'g');
        var new_id  = new Date().getTime();
            
        jQuery('#' + assoc + '_table tbody').append(content.replace(regexp, new_id));    
        return false;
      });
    });

This code uses jQuery. Users of prototype could build code that does the same
thing.

Example
=======

    class IceCream << ActiveRecord::Base
      # Enable a historical parameter price with id 1
      acts_as_historical_parameter :price, 1

      def get_sales_for_period(period_start, period_end)
        # Do some magic to load # of icecreams of this type
        # sold in the given period
      end

      def get_earnings_for_period(period_start, period_end)
        # Use block sumation to calculate
        price_sum do |period_start, period_end, price|
          # Multiply current price by # of icecreams sold
          get_sales_for_period(period_start, period_end) * value
        end
      end
    end

    # Load income from first ice for year to date.
    IceCream.find(1).get_earnings_for_period(Time.zone.now.beginning_of_year, Time.zone.now)

There are helpers to easilly create a form that allows editing of historical
parameters for a model. First if you need to create a form with historical
editing use the `historical_form_for` helper instead of a standard `form_for`.
This will setup the correct builder, this means a form for editing the
IceCreams from before will look like:

    <%= historical_form_for(@ice_cream) do |f| %>
      <!-- Fields for other attributes ... -->
      <%= f.historical_form_for :price %>
      <%= f.new_history_value_button :price %>
    <% end %>

Copyright (c) 2010 KeepFocus A/S, released under the MIT license

namespace :crawl_erp_data do
  desc 'Retrieve all ERP Gantry data from MyTransport.sg'
  task seed: :environment do

    puts 'Seeding Gantry Data...'
    puts '----------------------'
    if Gantry.all.empty?
      Gantry.make_gantries
    end
    puts 'Processing ERP Rates...'
    puts '----------------------'
    Price.process_erp_rates
    puts 'DONE!'
    puts '----------------------'
  end

  desc "TODO"
  task update: :environment do

  end

end

Given /^the test community has following available locales:$/ do |locale_table|
  @locales = []
  locale_table.hashes.each do |hash|
    @locales << hash['locale']
  end  
  
  #here is expected that the first community is the test community where the subdomain is pointing by default
  Community.first.update_attributes({:settings => { "locales" => @locales }})
end

Given /^the terms of community "([^"]*)" are changed to "([^"]*)"$/ do |community, terms|
  Community.find_by_domain(community).update_attribute(:consent, terms)
end

Then /^Most recently created user should be member of "([^"]*)" community with its latest consent accepted(?: with invitation code "([^"]*)")?$/ do |community_domain, invitation_code|
    # Person.last seemed to return unreliable results for some reason
    # (kassi_testperson1 instead of the actual newest person, so changed
    # to look for the latest CommunityMembership)
    
    community = Community.find_by_domain(community_domain)
    CommunityMembership.last.community.should == community
    CommunityMembership.last.consent.should == community.consent
    CommunityMembership.last.invitation.code.should == invitation_code if invitation_code.present?
end

Given /^given name and last name are not required in community "([^"]*)"$/ do |community|
  Community.find_by_domain(community).update_attribute(:real_name_required, 0)
end

Given /^community "([^"]*)" requires invite to join$/ do |community|
  Community.find_by_domain(community).update_attribute(:join_with_invite_only, true)
end

Given /^users can invite new users to join community "([^"]*)"$/ do |community|
  Community.find_by_domain(community).update_attribute(:users_can_invite_new_users, true)
end

Given /^there is an invitation for community "([^"]*)" with code "([^"]*)"(?: with (\d+) usages left)?$/ do |community, code, usages_left|
  inv = Invitation.new(:community => Community.find_by_domain(community), :code => code, :inviter_id => @people.first[1].id)
  inv.usages_left = usages_left if usages_left.present?
  inv.save
end

Then /^Invitation with code "([^"]*)" should have (\d+) usages_left$/ do |code, usages|
  Invitation.find_by_code(code).usages_left.should == usages.to_i
end

Given /^community "([^"]*)" is private$/ do |community|
  community = Community.find_by_domain(community).update_attribute(:private, true)
end

When /^I move to community "([^"]*)"$/ do |community|
  Capybara.default_host = "#{community}.lvh.me"
  Capybara.app_host = "http://#{community}.lvh.me:9887"
end

Given /^there is an existing community with "([^"]*)" in allowed emails and with slogan "([^"]*)"$/ do |email_ending, slogan|
  @existing_community = FactoryGirl(:community, :allowed_emails => email_ending, :slogan => slogan, :category => "company")
end

Given /^show me existing community$/ do
  puts "Email ending: #{@existing_community.allowed_emails}"
end


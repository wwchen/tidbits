require 'mechanize'
require 'highline/import'

## Work in progress
# Last update in Oct 31, 2012

state = 'wa'
user = 'user'

agent = Mechanize.new
agent.user_agent_alias = "Windows Mozilla"
agent.follow_meta_refresh = true
agent.pluggable_parser.pdf = Mechanize::FileSaver
login_form = agent.get('https://sitekey.bankofamerica.com/sas/signon.do?state=' + state).form
login_form.onlineId = ask("Username: ") { |q| q.echo = true }

sitekey_page = login_form.submit
sitekey_form = sitekey_page.form
challenge_q = sitekey_page.search("//label[@for='tlpvt-challenge-answer']").inner_html.gsub!(/\t/,'').chomp
challenge_a = ask(challenge_q + ": ") { |q| q.echo = '*' } 
sitekey_form.challengeQuestionAnswer = challenge_a

pw_form = sitekey_form.submit.form
password = ask("Password: ") { |q| q.echo = '*' } 
pw_form.password = password
pw_form.submit

acct_page = agent.get('https://safe.bankofamerica.com/myaccounts/accounts-overview/accounts-overview.go')
# stmt_links = acct_page.links_with(:text => %r/Statements \& Documents/)
# stmt_page = stmt_links.first.click

# links_form = forms_with(:name => "theLinkForm").first
# links_form = forms("theLinkForm")
# links = links_form.buttons_with(:value=> "Download")
# links.each { |l| pdf = links_form.click_button(l); l.node['title'] }
# File.open(local_filename, 'w') {|f| f.write(doc) }
#
# home -> account details -> statements
acct_page.links_with(:text => %r/View Account Details/i).each { |acct|
  form = acct.click.link_with(:text => 'Statements').click.form('theLinkForm')
  links = form.buttons_with(:value => 'Download')
  links.each do |link|
    title = link.node['title']
    form.submit(link)
    puts title
  end
}

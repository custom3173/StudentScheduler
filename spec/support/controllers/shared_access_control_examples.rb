module Controllers

  # use with require_group filter
  shared_examples 'action requires groups' do |groups, verb, action, options = {}|

    describe "require_group for: #{verb.upcase} ##{action}" do
      include_context 'ac_setup', action

      include_examples 'access control blocks action', verb, action, options

      Array(groups).each do |group|
        it "executes the action when the user is in group '#{group.to_s}'" do
          log_in_as({umbcusername: 'test_user', group: group.to_s})
          send(verb, action, options)
          expect(controller).to have_received(action)
        end
      end
    end
  end

  # use with require_attribute filter, checks for shibboleth
  # set attributes
  shared_examples 'action requires attribute'  do |attr, attr_value, verb, action, options = {}|

    describe "require_attribute for: #{verb.upcase} ##{action}" do
      include_context 'ac_setup', action

      include_examples 'access control blocks action', verb, action, options

      it "executes action when user has attribute :#{attr} => '#{attr_value}'" do
        log_in_as({umbcusername: 'test_user', group: nil})
        set_env_attribute(attr, attr_value)
        send(verb, action, options)
        expect(controller).to have_received(action)
      end
    end
  end

  # use with require_group_or_attribute filter, which checks
  #  for shibboleth set attributes in request.env, as well
  #  as any groups assigned to current_user
  shared_examples 'action requires groups or attribute' do |groups, attr, attr_value, verb, action, options = {}|
    include_examples 'action requires attribute', attr, attr_value, verb, action, options
    include_examples 'action requires groups', groups, verb, action, options
  end

  # used to DRY other example groups
  shared_examples 'access control blocks action' do |verb, action, options = {}|
    it 'does not execute the action when current user is not authorized' do
      log_in_as({umbcusername: 'unauthorized', group: nil})
      send(verb, action, options)
      expect(controller).not_to have_received(action)
    end
  end

  shared_context 'ac_setup' do |action|
    before do
      allow(controller).to receive(action)
      # prevents 'missing template' errors
      allow(controller).to receive(:render)
    end
  end
end
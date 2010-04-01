$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../../lib'))

require 'tmpdir'

require 'spec'
require 'spec/expectations'

require 'montage'

After do
  FileUtils.remove_entry_secure(@project.paths.root) if @project
end

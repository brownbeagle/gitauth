require 'test_helper'

class CommandTest < Test::Unit::TestCase
  
  context 'basic command checks' do
    
    should 'consider receive-pack as write' do
      assert command("git-receive-pack 'my-repo.git'").write?
      assert command("git receive-pack 'my-repo.git'").write?
    end
    
    should 'consider upload-pack as read' do
      assert command("git-upload-pack 'my-repo.git'").read?
      assert command("git upload-pack 'my-repo.git'").read?
    end
    
    should 'consider a non-git command as bad' do
      assert command("rm -rf /").bad?
      assert command("echo rock-and-roll").bad?
      assert command("svn-is-awesome").bad?
    end
    
    should 'allow valid git commands' do
      assert !command("git-receive-pack 'my-repo.git'").bad?
      assert !command("git receive-pack 'my-repo.git'").bad?
      assert !command("git-upload-pack 'my-repo.git'").bad?
      assert !command("git upload-pack 'my-repo.git'").bad?
      assert !command("git-receive-pack 'ninja/my-repo.git'").bad?
      assert !command("git receive-pack 'ninja/my-repo.git'").bad?
      assert !command("git-upload-pack 'ninja/my-repo.git'").bad?
      assert !command("git upload-pack 'ninja/my-repo.git'").bad?
    end
    
    should 'disallow paths without quotation marks' do
      assert command("git upload-pack my-repo.git").bad?
      assert command("git upload-pack my-repo/awesome.git").bad?
      assert command("git upload-pack 'my-repo.git").bad?
      assert command("git-upload-pack my-repo.git").bad?
      assert command("git-upload-pack my-repo/awesome.git").bad?
      assert command("git-upload-pack 'my-repo.git").bad?
      assert command("git receive-pack my-repo.git").bad?
      assert command("git receive-pack my-repo/awesome.git").bad?
      assert command("git receive-pack 'my-repo.git").bad?
      assert command("git-receive-pack my-repo.git").bad?
      assert command("git-receive-pack my-repo/awesome.git").bad?
      assert command("git-receive-pack 'my-repo.git").bad?
    end
    
  end
  
  protected
  
  def command(txt)
    GitAuth::Command.parse(txt)
  end
  
end
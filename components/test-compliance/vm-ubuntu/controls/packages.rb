title 'software packages'

control 'packages-01' do
    impact 1.0
    title 'Packages should be installed'
    desc 'Required software packages should be installed'

    PACKAGES = %w(
        apt-transport-https
        ca-certificates
        curl
        gnupg
        lsb-release
        git
        tilix
        tmux
        vim
        ncdu
        neofetch
        htop
        jq
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
        inspec
        k9s
        ansible
    )
    PACKAGES.each do |p|
        describe package(p) do
            it { should be_installed }
        end
    end
end

control 'packages-02' do
    impact 0.5
    title 'Snap packages should be installed'
    desc 'Required snap packages should be installed'

    SNAPS = %w(
        /snap/bin/code
    )
    SNAPS.each do |s|
        describe file(s) do
            it { should exist }
            it { should be_file }
            it { should_not be_directory }
            it { should be_executable }
        end
    end
end

control 'packages-03' do
    impact 1.0
    title 'Binary commands should be installed'
    desc 'Required binary commands should be installed'

    COMMANDS = %w(
        /usr/local/bin/helm
        /usr/local/bin/minikube
        /usr/local/bin/argocd-autopilot
    )
    COMMANDS.each do |c|
        describe file(c) do
            it { should exist }
            it { should be_file }
            it { should_not be_directory }
            it { should be_executable }
        end
    end
end

control 'packages-99' do
    impact 1.0
    title 'No installation artifacts should remain on the system'
    desc 'No installation artifacts should remain on the system, all downloads and scripts should be removed'

    ARTIFACT = %w(
        /tmp/minikube-linux-amd64
        /tmp/get_helm.sh
        /tmp/inspec.deb
        /tmp/k9s.deb
    )
    ARTIFACT.each do |a|
        describe file(a) do
            it { should_not exist }
        end
    end
end

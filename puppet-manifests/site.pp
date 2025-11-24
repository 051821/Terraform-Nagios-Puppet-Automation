# For Puppet Master (Linux)
node 'puppetmaster.example.com' {
  include project1::linux
}

# For Windows Agent
node 'win-agent.example.com' {
  include project1::windows
}

# Fallback for all other nodes
node default {
  notify { "Default node applied (no specific class set)": }
}

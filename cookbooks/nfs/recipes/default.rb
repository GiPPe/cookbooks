package "net-fs/nfs-utils"

service "rpcbind.service" do
  action [:enable, :start]
end

service "rpc-mountd.service" do
  action [:enable, :start]
end

service "rpc-statd.service" do
  action [:enable, :start]
end

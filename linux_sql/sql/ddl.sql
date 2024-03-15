-- Define the host information table
CREATE TABLE IF NOT EXISTS HostInfo (
    Id SERIAL PRIMARY KEY,
    Hostname VARCHAR NOT NULL UNIQUE,
    CpuNumber SMALLINT NOT NULL,
    CpuArchitecture VARCHAR NOT NULL,
    CpuModel VARCHAR NOT NULL,
    CpuSpeed DECIMAL(8,2) NOT NULL,
    L2CacheSize INT NOT NULL,
    Timestamp TIMESTAMP,
    TotalMemory INT,
    CONSTRAINT FK_HostInfo_Id FOREIGN KEY (Id) REFERENCES HostUsage(HostId)
);

-- Define the host usage table
CREATE TABLE IF NOT EXISTS HostUsage (
    Timestamp TIMESTAMP NOT NULL,
    HostId SERIAL NOT NULL,
    MemoryFree INT NOT NULL,
    CpuIdlePercentage SMALLINT NOT NULL,
    CpuKernelPercentage SMALLINT NOT NULL,
    DiskIO INT NOT NULL,
    DiskAvailable INT NOT NULL,
    CONSTRAINT PK_HostUsage PRIMARY KEY (Timestamp, HostId),
    CONSTRAINT FK_HostUsage_HostId FOREIGN KEY (HostId) REFERENCES HostInfo(Id)
);

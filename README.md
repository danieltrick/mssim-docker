MS TPM 2.0 Simulator Docker
===========================

The purpose of this repository is to provide ready to use Docker images of [`ms-tpm-20-ref`](https://github.com/microsoft/ms-tpm-20-ref).

**Docker Hub page:**  
<https://hub.docker.com/r/danieltrick/mssim-docker>


Usage
-----

To start the MS TPM 2.0 simulator via Docker, simply run:

```sh
$ docker run -p 127.0.0.1:2321-2322:2321-2322 danieltrick/mssim-docker:r6
```

### TPM 2.0 Software Stack

The easiest way to work with the TPM simulator is via the **TPM 2.0 Software Stack (TSS2)**:
- <https://github.com/tpm2-software/tpm2-tss>
- <https://github.com/tpm2-software/rust-tss-fapi>

#### Configuration

You can set up TSS2 to use the TPM simulator with the following TCTI configuration:
```
mssim:host=127.0.0.1,port=2321
```

For details, please refer to:  
<https://github.com/tpm2-software/tpm2-tss/blob/master/doc/tcti.md#tcti-mssim>

### Example

Here is a simple example that uses [**`tpm2-tools`**](https://github.com/tpm2-software/tpm2-tools) to request random bytes from the TPM simulator:

1. Run the `TPM2_Startup` command, if not done already:
   ```sh
   $ tpm2_startup -T mssim:host=127.0.0.1,port=2321 -c
   ```

2. Now run the `TPM2_GetRandom` command:
   ```sh
   $ tpm2_getrandom -T mssim:host=127.0.0.1,port=2321 --hex 16
   ```

Version history
---------------

| **Release** | **Date**   | **Base system**            | **MSSIM Version**         | **MSSIM Commit**                                                                              |
| ------------| ---------- | -------------------------- | ------------------------- |---------------------------------------------------------------------------------------------- |
| r6          | 2026-01-29 | Alpine 3.23.3 (2026-01-28) | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |
| r5          | 2026-01-06 | Alpine 3.23.2 (2025-12-17) | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |
| r4          | 2025-06-12 | Debian 12, 2025-06-10      | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |
| r3          | 2025-02-25 | Debian 12, 2025-02-24      | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |
| r2          | 2025-01-20 | Debian 12, 2025-01-13      | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |
| r1          | 2024-11-21 | Debian 12, 2024-11-11      | 1.83-r1                   | [`ee21db0a941d`](https://github.com/microsoft/ms-tpm-20-ref/commit/ee21db0a941d) (2024-10-04) |

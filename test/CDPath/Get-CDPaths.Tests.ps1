using namespace System.Diagnostics.CodeAnalysis
using module '..\..\posh-terminator\src\CDPath.psm1'

Describe 'CDPath' {
  InModuleScope CDPath {
    Describe 'Get-CDPaths' {
      Context 'CDPATH is not set' {
        It 'returns empty array' {
          Mock Get-CDPathVariable { }
          Get-CDPaths | Should -Be @()
          Assert-MockCalled Get-CDPathVariable
        }
      }

      Context 'CDPATH is set' {
        BeforeEach {
          $scriptRoot = $PSScriptRoot
          $cdPath = ".;~/.homesick/repos;~/;$scriptRoot"
          Mock Get-CDPathVariable { $cdPath }
        }

        Context '-Unique: $false' {
          It 'returns all paths' {
            Get-CDPaths | Should -Be @('.', '~/.homesick/repos', '~/', $scriptRoot)
            Assert-MockCalled Get-CDPathVariable
          }

          Context 'In duplicate path' {
            It 'returns all paths' {
              Set-Location $scriptRoot
              Get-CDPaths | Should -Be @('.', '~/.homesick/repos', '~/', $scriptRoot)
              Assert-MockCalled Get-CDPathVariable
              Set-Location -
            }
          }
        }

        Context '-Unique: $true' {
          It 'returns all paths' {
            Get-CDPaths -Unique | Should -Be @('.', '~/.homesick/repos', '~/', $scriptRoot)
            Assert-MockCalled Get-CDPathVariable
          }

          Context 'In duplicate path' {
            It 'returns unique paths' {
              Set-Location $scriptRoot
              Get-CDPaths -Unique | Should -Be @('.', '~/.homesick/repos', '~/')
              Assert-MockCalled Get-CDPathVariable
              Set-Location -
            }
          }
        }
      }
    }
  }
}
